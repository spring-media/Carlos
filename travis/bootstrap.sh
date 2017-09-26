#!/bin/sh

bundle exec carthage bootstrap --platform ios
cp Cartfile.resolved Carthage
