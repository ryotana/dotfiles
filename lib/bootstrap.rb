# helper methods
MItamae::RecipeContext.class_eval do
  def include_node(name)
    root_dir = File.expand_path("../..", __FILE__)
    return unless File.exist?(File.join(root_dir, "nodes", "#{name}.rb"))
    include_recipe File.join(root_dir, "nodes", name)
  end

  def include_role(name)
    root_dir = File.expand_path("../..", __FILE__)
    return unless File.exist?(File.join(root_dir, "roles", name, "default.rb"))
    include_recipe File.join(root_dir, "roles", name, "default")
  end

  def include_cookbook(name)
    root_dir = File.expand_path("../..", __FILE__)
    include_recipe File.join(root_dir, "cookbooks", name, "default")
  end

  def include_plugin(name)
    root_dir = File.expand_path("../..", __FILE__)
    plugin_dir = File.join(root_dir, "plugins", name)
    return unless File.exist?(plugin_dir)

    node_file = File.join(plugin_dir, "node.rb")
    include_recipe node_file if File.exist?(node_file)

    recipe_file = File.join(plugin_dir, "recipes", "default.rb")
    include_recipe File.join(plugin_dir, "recipes", "default") if File.exist?(recipe_file)
  end

  def plugin_fragments(fragment_path)
    root_dir = File.expand_path("../..", __FILE__)
    fragments = []
    (node[:plugins] || []).each do |plugin_name|
      dir = File.join(root_dir, "plugins", plugin_name, "dotfiles", fragment_path)
      if File.directory?(dir)
        Dir.glob(File.join(dir, "*")).sort.each do |f|
          fragments << File.read(f)
        end
      end
    end
    fragments.join("\n")
  end

  def plugin_template_fragment(template_name)
    root_dir = File.expand_path("../..", __FILE__)
    fragments = []
    (node[:plugins] || []).each do |plugin_name|
      f = File.join(root_dir, "plugins", plugin_name, "templates", template_name)
      fragments << File.read(f) if File.exist?(f)
    end
    fragments.join("\n")
  end
end

# include attributes
case node[:platform]
when "darwin"
  include_node "darwin"
when "redhat", "amazon"
  include_node "linux"
else
  raise "#{node[:platform]} not implemented"
end

include_node "common"
include_node node[:hostname]

# include roles
include_role "common"

if node[:is_darwin]
  include_role "darwin"
elsif node[:is_linux]
  include_role "linux"
end

# include plugins
(node[:plugins] || []).each do |plugin|
  include_plugin plugin
end

# include cookbooks
(node[:cookbooks] ||= []).each do |cookbook|
  include_cookbook cookbook
end
