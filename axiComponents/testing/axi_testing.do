
transcript quietly
onbreak {resume}

cd ../subDevices/loopbackDevice/sim/
do loopback_device_rtl.do
quit -sim 

cd ../..
cd infoDevice/sim/
do info_device_rtl.do
quit -sim


cd ../../../testing