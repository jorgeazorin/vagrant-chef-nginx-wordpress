#PHP
apt_repository 'ondrej-php' do
    uri          'ppa:ondrej/php'
end

execute "apt-get update"

[ 'php', 'php-fpm','php-mysql', 'php-xml' ].each do |p|
    package p do
      action :install
    end
end   

package 'apache2' do
    action :remove
end







# Nginx
package 'nginx' do
    action :install
end

service "nginx" do
   supports :status => true, :restart => true, :reload => true
   action [ :enable, :start ]
end

file '/etc/nginx/sites-available/default' do
    action :delete
end

link '/etc/nginx/sites-enabled/default' do
    to '/etc/nginx/sites-available/default'
    action :delete
end


cookbook_file "/etc/nginx/sites-available/wordpress" do
    source "wordpress"
    owner "root"
    group "root"
    mode "0655"
    action :create_if_missing
    notifies :restart, resources(:service => "nginx"), :delayed
end

link '/etc/nginx/sites-enabled/wordpress' do
    to '/etc/nginx/sites-available/wordpress'
    action :create
end



# MySQL
mysql_service 'default' do
    port '3306'
    initial_root_password 'change me'
    action [:create, :start]
end





# WORDPRESS
execute "create-wordpress-database" do
    command "mysql -h 127.0.0.1 -u root -p'change me' < /tmp/script.sql"
    action :nothing
end
cookbook_file "/tmp/script.sql" do
    source "script.sql"
    owner "root"
    group "root"
    mode "0655"
    action :create_if_missing
    notifies :run, 'execute[create-wordpress-database]', :immediately
end


execute "import-wrodpress-database" do
    command "mysql -h 127.0.0.1 -u root -p'change me' wordpress < /tmp/wp-database.sql"
    action :nothing
end
cookbook_file "/tmp/wp-database.sql" do
    source "wp-database.sql"
    owner "vagrant"
    group "vagrant"
    action :create_if_missing
    notifies :run, 'execute[import-wrodpress-database]', :immediately
end



cookbook_file "/tmp/wordpress.zip" do
    source "wordpress.zip"
    owner "vagrant"
    group "vagrant"
    action :create_if_missing
end

archive_file "wordpress.zip" do
    path "/tmp/wordpress.zip"
    extract_to "/var/www/"
    action :extract
    extract_options [:no_overwrite]
end


cookbook_file "/var/www/wordpress/wp-config.php" do
    source "wp-config.php"
    owner "vagrant"
    group "vagrant"
    action :create_if_missing
end




