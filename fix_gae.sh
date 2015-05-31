#!/bin/bash

conf_file=gae_conf.ini
if [ ! -e $conf_file ] ; then
    echo "Config file '$conf_file' not exist, use \"echo /path/to/gae/local >> $conf_file to create it.\""
    exit 1
fi

## read gae proxy.ini directory
gae_dir=$(cat $conf_file)
gae_conf=proxy.ini
gae_conf_back=proxy.ini.back
output=output.txt

## sanity check
if [ -z $gae_dir ] ; then
    echo "GAE proxy.ini directory not configured, use \"echo /path/to/gae/local >> $conf_file to create it.\""
    exit 1
fi

if [ ! -e "$gae_dir/$gae_conf" ] ; then
    echo "Configure file '$gae_dir/$gae_conf' not exist."
    exit 1
fi

## detect google ips
python google.py -n 200 -m 10 &>/dev/null
if [ $? -ne 0 ] ; then
    echo "Detect script exit with code 2, please manualy run it."
    exit 1
fi

if [ ! -e "$output" ] ; then
    echo "Output file '$output' not exist."
    exit 1
fi

## backup current proxy.ini
cp $gae_dir/$gae_conf $gae_dir/proxy.ini.back

## replace output file content to proxy.ini
sed "s/^google_hk = .*$/google_hk = $(cat output.txt)/g" -i $gae_dir/$gae_conf

## restore output.txt
git checkout $output
