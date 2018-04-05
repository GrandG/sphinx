


sphinx:
	sphinx-build -b html "./source" "./build"
	start ./build/index.html
	echo "sphinx-build done"