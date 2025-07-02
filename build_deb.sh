#! /bin/bash
#build_deb.sh


rm -rf yandi-archive-keyring/.git
rm -rf yandi-archive-keyring/LICENSE
rm -rf yandi-archive-keyring/README.md

dpkg-deb --root-owner-group --build yandi-archive-keyring

mv yandi-archive-keyring.deb yandi-archive-keyring_1.0.0-1+deb12u1_all.deb
