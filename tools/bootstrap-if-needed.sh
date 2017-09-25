#!/bin/sh

cmp -s Cartfile.resolved Carthage/Cartfile.resolved || travis/bootstrap.sh
