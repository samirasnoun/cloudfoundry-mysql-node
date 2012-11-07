#
# Cookbook Name:: cloudfoundry-msyql-service
# Recipe:: default
#
# Copyright 2012, Trotter Cashion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#default['cloudfoundry_mysql_service']['cf_session']['cf_id'] = '1'
#default['cloudfoundry_mysql_service']['cf_session']['name'] = ''


if Chef::Config[:solo]
   Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else 

node.set['cloudfoundry_common']['cf_session']['cf_id'] = node['cloudfoundry_mysql_service']['cf_session']['cf_id']

include_recipe 'cloudfoundry-common'

#sudo apt-get install libsqlite3-dev 
#sudo apt-get install libmysqlclient-dev


  cf_id_node = node['cloudfoundry_mysql_service']['cf_session']['cf_id']
  m_nodes = search(:node, "role:cloudfoundry_controller AND cf_id:#{cf_id_node}")

   while m_nodes.count < 1 
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        m_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}")        
       end
    Chef::Log.warn("Nats server found i am saving it")

   m_node = m_nodes.first
  
  node.set['cloudfoundry_mysql_service']['searched_data']['cloudfoundry_cloud_controller']['server']['api_uri'] = "" + m_node.ipaddress + ":" + m_node['cloudfoundry_cloud_controller']['server']['external_port'].to_s  #m_node.cloudfoundry_cloud_controller.server.api_uri
  node.set['cloudfoundry_mysql_service']['searched_data']['cloudfoundry_common']['service_token'] = m_node.cloudfoundry_common.service_token
  
  n_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node} ")
  n_node = n_nodes.first
  
  node.set['cloudfoundry_mysql_service']['searched_data']['nats_server']['host'] = n_node.ipaddress  
  node.set['cloudfoundry_mysql_service']['searched_data']['nats_server']['user'] = n_node.nats_server.user
  node.set['cloudfoundry_mysql_service']['searched_data']['nats_server']['password'] = n_node.nats_server.password
  node.set['cloudfoundry_mysql_service']['searched_data']['nats_server']['port'] = n_node.nats_server.port

  package 'libsqlite3-dev'
  package 'libmysqlclient-dev'

  include_recipe "cloudfoundry-mysql-node::node"

end 
