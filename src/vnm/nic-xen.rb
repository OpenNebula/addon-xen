# -------------------------------------------------------------------------- #
# Copyright 2002-2015, OpenNebula Project, OpenNebula Systems                #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

module VNMMAD

module VNMNetwork
    ############################################################################
    # Hypervisor specific implementation of network interfaces. Each class
    # implements the following interface:
    #   - get_info to populste the VM.vm_info Hash
    #   - get_tap to set the [:tap] attribute with the associated NIC
    ############################################################################

    # A NIC using Xen. This class implements functions to get the physical interface
    # that the NIC is using
    class NicXen < Hash
        VNMNetwork::HYPERVISORS["xen"] = self

        def initialize
            super(nil)
        end

        def get_info(vm)
            if vm.deploy_id
                deploy_id = vm.deploy_id
            else
                deploy_id = vm['DEPLOY_ID']
            end

            if deploy_id and (vm.vm_info[:domid].nil? or vm.vm_info[:networks].nil?)
                vm.vm_info[:domid]    =`sudo xl domid #{deploy_id}`.strip
                vm.vm_info[:networks] =`sudo xl network-list #{deploy_id}`

                vm.vm_info.each_key do |k|
                    vm.vm_info[k] = nil if vm.vm_info[k].to_s.strip.empty?
                end
            end
        end

        def get_tap(vm)
            domid = vm.vm_info[:domid]

            if domid
                networks = vm.vm_info[:networks].split("\n")[1..-1]
                networks.each do |net|
                    n = net.split

                    iface_id  = n[0]
                    iface_mac = n[2]

                    self[:tap] = "vif#{domid}.#{iface_id}"
                    break
                end
            end
            self
        end
    end
end
end
