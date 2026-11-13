#!/usr/bin/env python3
"""Read Azgaar 1.158 map records without dumping SVG or cell arrays.

This is an inspection tool, not a lore source. Unverified generated fields
must not be treated as Astaria canon. Record delimiters are CRLF, not LF.
"""
import argparse
import json
from pathlib import Path
import xml.etree.ElementTree as ET

SECTIONS = {
    'options': 1, 'biomes': 3, 'svg': 5, 'grid': 6, 'features': 12,
    'cultures': 13, 'states': 14, 'burgs': 15, 'religions': 29,
    'provinces': 30, 'rivers': 32, 'fonts': 34, 'markers': 35,
    'cell_routes': 36, 'routes': 37, 'zones': 38, 'ice': 39,
    'markets': 42, 'deals': 43, 'measurers': 46, 'labels': 47,
    'styles': 48, 'relief': 49, 'layers': 50,
    'graph_override': 51, 'journeys': 52, 'legends': 53,
}
CELL_ARRAYS = {
    'biome':16, 'burg':17, 'conf':18, 'culture':19, 'fl':20,
    'pop':21, 'r':22, 's':24, 'state':25, 'religion':26,
    'province':27, 'good':40, 'market':44, 'prosperity':54,
    'development':55,
}

class MapFile:
    def __init__(self, path):
        self.path = Path(path)
        self.records = self.path.read_bytes().decode('utf-8').split('\r\n')
        if not self.records[0].startswith('1.158.0|') or len(self.records) != 56:
            raise ValueError('Expected Azgaar 1.158.0 with 56 CRLF records')

    def get(self, name):
        return json.loads(self.records[SECTIONS[name]])

    def put(self, name, value):
        self.records[SECTIONS[name]] = json.dumps(value, ensure_ascii=False, separators=(',', ':'))

    def save(self):
        self.path.write_bytes('\r\n'.join(self.records).encode('utf-8'))

    def validate(self):
        for name in SECTIONS:
            if name != 'svg':
                self.get(name)
        ET.fromstring(self.records[5])
        counts = {name: len(self.records[i].split(',')) for name,i in CELL_ARRAYS.items()}
        if len(set(counts.values())) != 1:
            raise ValueError('Unequal packed-cell array lengths: '+str(counts))
        for cell_name, section in [('burg','burgs'),('culture','cultures'),('state','states'),('religion','religions'),('province','provinces')]:
            entries = self.get(section)
            alive = {0} | {x['i'] for x in entries if isinstance(x,dict) and not x.get('removed') and 'i' in x}
            used = set(map(int,self.records[CELL_ARRAYS[cell_name]].split(',')))
            if used-alive:
                raise ValueError('Dangling '+cell_name+' IDs: '+str(used-alive))
        for name in ['burgs','states','cultures','religions','features']:
            for index, item in enumerate(self.get(name)):
                if isinstance(item,dict) and item.get('i') != index:
                    raise ValueError('Unstable index in '+name)
        return {'packed_cells':next(iter(counts.values())), 'records':len(self.records)}

    def summary(self, names=False):
        result = {'path':str(self.path), 'version':self.records[0].split('|')[0], 'validation':self.validate(),
                  'canvas':self.get('options')['graph'], 'units':self.get('options')['units'],
                  'calendar':self.get('options')['lore']['calendar']}
        result['canvas'] = {k:result['canvas'][k] for k in ['width','height']}
        for section in ['burgs','states','cultures','religions','provinces','features','rivers','labels','routes','markets','deals','relief']:
            items = self.get(section)
            active = [x for x in items if isinstance(x,dict) and not x.get('removed') and x.get('i',1)]
            result[section] = {'records':len(items), 'active':len(active)}
            if names and section in ['burgs','states','cultures','religions','features','rivers','labels']:
                result[section]['names'] = [{'id':x.get('i'), 'name':x.get('name',x.get('label',{}).get('text'))} for x in active]
        return result

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('map',type=Path)
    parser.add_argument('--names',action='store_true')
    args=parser.parse_args()
    print(json.dumps(MapFile(args.map).summary(args.names),ensure_ascii=False,indent=2))
