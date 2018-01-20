if [ ! -d "out" ]; then
	mkdir out
fi

cd src
make clean
make
cd ..
