#!/usr/bin/env bash

# go to project root.
if [[ $(pwd) == *Scripts ]]; then
    cd ..
fi

ver=$(grep "VERSION = " Source/FunPlusSDK.swift | sed "s/\"//g" | sed "s/public static let VERSION = //g")
out=$(echo Release/funplus-ios-sdk-$ver | tr -d ' ')

echo SDK version: $ver
echo Output directory: $out

# check output directory.
if [ -d $out ]; then
    read -p 'Directory exists. This action will erase the existing directory, are you sure? [yN] ' yn
    if [[ $yn != 'y' && $yn != 'Y' ]]; then
        echo exit
        exit
    else
        rm -rf $out
    fi
fi

echo

# prepare output directory.
mkdir $out

# copy docs
cp {README,CHANGELOG}.md $out/

# build device SDK
xcodebuild -target FunPlusSDK -configuration Release -sdk iphoneos10.1

# build simulator SDK
xcodebuild -target FunPlusSDK -configuration Release -sdk iphonesimulator10.1

build_dir=Build/Products
device_framework=$build_dir/Release-iphoneos/FunPlusSDK.framework
simulator_framework=$build_dir/Release-iphonesimulator/FunPlusSDK.framework
fat_framework=$build_dir/FunPlusSDK.framework

lipo -create -output $build_dir/FunPlusSDK $device_framework/FunPlusSDK $simulator_framework/FunPlusSDK
cp -R $device_framework $fat_framework
mv $build_dir/FunPlusSDK $fat_framework/FunPlusSDK
cp -R $fat_framework $out/FunPlusSDK.framework