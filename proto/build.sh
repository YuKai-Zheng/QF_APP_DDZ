#!/bin/sh

# code
mkdir -p python java cpp
protoc -I=. --python_out=python --java_out=java --cpp_out=cpp ./texas_net.proto
