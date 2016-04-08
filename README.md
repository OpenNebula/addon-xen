# Xen Hypervisor support for OpenNebula

## Description

The [XEN hypervisor](http://www.xen.org) offers a powerful, efficient and secure feature set for virtualization of x86, IA64, PowerPC and other CPU architectures. It delivers both paravirtualization and full virtualization. This guide describes the use of Xen with OpenNebula, please refer to the Xen specific documentation for further information on the setup of the Xen hypervisor itself.

This addon is compatible **only** with Xen 4. Xen 3 has been deprecated in OpenNebula.

## Authors

* Leader: [Héctor San Juan](https://github.com/hsanjuan)
* [OpenNebula Core Team](https://github.com/OpenNebula)

## Features

* Extend the hypervisors supported by OpenNebula with Xen
* Allows paravirtualization which performs very well

## Compatibility

This add-on is compatible with:

| OpenNebula Version |
| ------------------ |
| 5.0                |
| 4.14.2             |
| 4.10, 4.12         |

## Installation

To install this add-on, clone it and run install.sh:

    sudo ./install.sh -u oneadmin -g oneadmin

You wil need to add the following to `/etc/one/oned.conf`: [oned.conf for Xen](oned-xen.conf)

## Usage

The usage guide can be found here: [Xen Driver](docs/xeng.rst)

## Configuration

There are two configuration files:

* ``/etc/one/vmm_exec/vmm_exec_xen.conf``: Defines the default values for VM templates: ``credit``, ``os [kernel,initrd,root,kernel_cmd,hvm]``, ``vcpu``, ``features [acpi, pae, apic, device_model, localtime]``, ``disk[driver]``, ``nic[model]`` and ``raw``.
* ``/var/lib/one/remotes/xen/xenrc``: Defines location of the Xen commands.

## Development

To contribute bug patches or new features, you can use the github Pull Request model. It is assumed that code and documentation are contributed under the Apache License 2.0.
