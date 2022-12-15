import sys
import json

data = None
with open('guan-kevin-hunting-ground4.0.json', 'r') as f:
    data = json.load(f)

if not data:
    print('Cannot open test.json file.')
    sys.exit(1)

latest_push_build_pair = None
latest_pull_build_pair = None

with open('guan-kevin-hunting-ground4.0.json', 'w') as f:
    for build_pair in data:
        if build_pair['branch'] == 'pull_request':
            if latest_pull_build_pair is None or build_pair['failed_build']['build_id'] > latest_pull_build_pair['failed_build']['build_id']:
                latest_pull_build_pair = build_pair
        else:
            if latest_push_build_pair is None or build_pair['failed_build']['build_id'] > latest_push_build_pair['failed_build']['build_id']:
                latest_push_build_pair = build_pair
                
    if latest_push_build_pair and latest_pull_build_pair:
        json.dump([latest_push_build_pair, latest_pull_build_pair], f)
        sys.exit(0)

print('Cannot find the most recent job pairs.')
print(data)
sys.exit(1)
