GH_TOKEN=$1
REPOSITORY=$2
TEST_REPOSITORY=$3

docker pull bugswarm/containers:bugswarm-db
docker tag bugswarm/containers:bugswarm-db test-bugswarm-db
docker run -itd -p 127.0.0.1:27017:27017 -p 127.0.0.1:5000:5000 test-bugswarm-db

git clone https://$GH_TOKEN@github.com/$TEST_REPOSITORY.git repo > /dev/null

pushd repo/bugswarm/common
cp credentials.sample.py credentials.py
sed -i "s/DATABASE_PIPELINE_TOKEN = .*/DATABASE_PIPELINE_TOKEN = 'testDBPassword'/g" credentials.py
sed -i "s/COMMON_HOSTNAME = .*/COMMON_HOSTNAME = '127.0.0.1:5000'/g" credentials.py
sed -i "s/GITHUB_TOKENS = .*/GITHUB_TOKENS = ['$GH_TOKEN']/g" credentials.py
sed -i "s/TRAVIS_TOKENS = .*/TRAVIS_TOKENS = ['<dummy travis token>']/g" credentials.py
sed -i "s/''/'#'/g" credentials.py
popd

pushd repo
pip install -e .

sed -i "s/.*python3 pair_finder.py --keep-clone --repo \${repo} .*/python3 pair_finder.py --keep-clone --repo \${repo} --threads \${threads} --cutoff-days 1/g" run_mine_project.sh
./run_mine_project.sh -r $REPOSITORY

git checkout reproducer
popd 

pushd repo/reproducer
python3 pair_chooser.py -o test.json -r  $REPOSITORY
python3 ~/tester/tests/select_most_recent_buildpairs.py
popd

pushd repo/reproducer
python3 entry.py -i test.json -t 6 -s -o test
popd
