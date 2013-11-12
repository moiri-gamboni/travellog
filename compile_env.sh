#!/bin/bash
coffee -o static/ -cw assets/ &
stylus -w assets/css/style.styl -o static/css/ 
