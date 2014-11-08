#!/bin/bash
stylus -c theme/theme.styl
cd theme && zip -r ../theme.zip ./* -x \*.styl \*.DS_Store