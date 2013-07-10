Option Explicit
' This file contains the functions to manage host-only interfaces in the system


function get_hostonly_interfaces() 
' Returns: 
	get_hostonly_interfaces = get_vbox_value ("list hostonlyifs", "Name")
	'echo -e `VBoxManage list hostonlyifs | grep '^Name' | sed 's/^Name\:[ \t]*//' | uniq` 
end function


function is_hostonly_interface_present(name) 
' Check if interface is in list of host-only interfaces
' Returns: boolean
	dim lstIfs, arrIfs, i
	lstIfs = get_hostonly_interfaces()
	arrIfs = Split(lstIfs,vbcrlf)
	' Check that the list of interfaces contains the given interface
	is_hostonly_interface_present = false
	for i = 0 to Ubound(arrIfs)
		if arrIfs(i) = name then
			is_hostonly_interface_present = True
			exit for 
		end if
	next
end function
'wscript.echo is_hostonly_interface_present("VirtualBox Host-Only Ethernet Adapter") 


function check_hostonly_interface(name, ip, mask)
' Check if interface have given ip address and mask
' Returns: boolean 
	Dim listing, arrLines, linesNb, i
	listing = get_vbox_value ("list hostonlyifs", "(Name|IPAddress|NetworkMask)")
	arrLines = Split(listing,vbcrlf)
	linesNb = Ubound(arrLines) + 1
	if linesNb Mod 3 <> 0 then
		wscript.echo "Something went wrong..."
		exit function
	end if
	check_hostonly_interface = False
	for i = 0 to linesNb-1 step 2
		if arrLines(i) = name then
			if arrLines(i+1) = ip and arrLines(i+2) = mask then
				check_hostonly_interface = True
			else
				check_hostonly_interface = False
			end if
			exit for
		end if
	next
end Function 
'wscript.echo check_hostonly_interface("VirtualBox Host-Only Ethernet Adapter", "192.168.56.1", "255.255.255.0")


function surely_create_hostonly_interface(byref name, ip, mask)
' Create hostonly interface and configure it with IP and mask.
' If created interface have different name value if name variable changes.
' Sometimes VBoxManage can't properly configure IP at hostonly interface. 
' In case if IP and mask not configured properly interface deleted and recreated in loop.
' Returns: nothing
	dim i, max_tries, sleep_seconds
	max_tries = 5
	sleep_seconds = 5
	surely_create_hostonly_interface = False

	for i = 1 to max_tries
		if is_hostonly_interface_present(name) then 
			delete_hostonly_interface name
			WScript.sleep sleep_seconds * 1000
		end if

		create_hostonly_interface name, ip, mask

		if is_hostonly_interface_present(name) then 
			if check_hostonly_interface (name, ip, mask) then
				surely_create_hostonly_interface = True
				exit for
			else
				wscript.echo "Interface was not created properly."
			end if
		end if

		WScript.sleep sleep_seconds * 1000
	next
end Function 
'wscript.echo surely_create_hostonly_interface ("VirtualBox Host-Only Ethernet Adapter #8", "192.168.1.1", "255.255.255.0")


function create_hostonly_interface(byref name, ip, mask)
' Create hostonly interface and configure it with IP and mask
' If created interface have different name value if name variable changes.
' Returns: nothing
	wscript.echo "Creating host-only interface (name ip netmask): " & name  & " " & ip & " " & mask
	' Exit if the interface already exists (deleting it here is not safe, as VirtualBox creates hostonly adapters sequentially)
	if is_hostonly_interface_present (name) then
		wscript.echo "Fatal error. Interface " + name + " cannot be created because it already exists."
		exit Function
	end if

	dim ret, rxp, m
	Set rxp = New RegExp : rxp.Global = True : rxp.Multiline = True
	rxp.Pattern = "Interface '([^']+)' was successfully created"

	' Create the interface
	ret = call_VBoxManage ("hostonlyif create")
	set m = rxp.Execute(ret(1)) 
	if m.count > 0 then
		name = m(0).SubMatches(0)
	end if

	' If it does not exist after creation, let's abort
	if not is_hostonly_interface_present (name) then
		wscript.echo "Fatal error. Interface " + name + " does not exist after creation."
		exit Function
	end if

	' Disable DHCP
	wscript.echo "Disabling DHCP server on interface: " + name + "..."
	'VBoxManage dhcpserver remove --ifname $name 2>/dev/null
	call_VBoxManage "dhcpserver remove --ifname """ + name  + """"

	' Set up IP address and network mask
	wscript.echo "Configuring IP address " + ip + " and network mask " + mask + " on interface: " + name + "..."
	call_VBoxManage "hostonlyif ipconfig """ + name + """ --ip " + ip + " --netmask " + mask
end function


Function delete_hostonly_interface(name)
' Delete given host-only interface
' Returns: nothing
		wscript.echo "Deleting host-only interface: " + name + "..."
		call_VBoxManage "hostonlyif remove """ + name + """"
end Function


function delete_all_hostonly_interfaces() 
' Delete all host-only interfaces
' Returns: nothing
	dim list, interface
	list=split(get_hostonly_interfaces(), vbcrlf)

	' Delete every single hostonly interface in the system
	for each interface in list 
		delete_hostonly_interface(interface)
	next
end function

