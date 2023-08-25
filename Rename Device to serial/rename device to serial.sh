#!/bin/zsh
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
scutil --set HostName $serialNumber
scutil --set LocalHostName $serialNumber
scutil --set ComputerName $serialNumber