#!/bin/bash
cd `dirname "$0"`
rm -rf docs
headerdoc2html -o docs ./Classes/
gatherheaderdoc docs