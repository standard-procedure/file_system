# FileSystem

A Rails engine that provides a comprehensive file system implementation with polymorphic associations, hierarchical folder structures, versioning, and access control.

## Features

- **Volume Management**: Base containers for organizing your file system
- **Hierarchical Folders**: Nested folder structures with parent-child relationships
- **Item Versioning**: Track revisions of items with numbered versions
- **Polymorphic Associations**: Connect files to any model in your application
- **Rich Text Comments**: Comment on item revisions using ActionText
- **Access Control Lists**: Fine-grained permissions for folders with a normalized approach
- **Metadata Storage**: Flexible serialized metadata for both items and revisions
- **Soft Deletion**: Preserve data with active/deleted status

## Installation

Add this line to your application's Gemfile:

```ruby
gem "file_system"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install file_system
```

## Usage

### Basic Setup

Mount the engine in your routes:

```ruby
Rails.application.routes.draw do
  mount FileSystem::Engine => "/file_system"
end
```

Run the migrations:

```bash
$ bin/rails file_system:install:migrations
$ bin/rails db:migrate
```

### Creating Volumes and Folders

```ruby
# Create a volume
volume = FileSystem::Volume.create(name: "Project Files")

# Create folders
root_folder = volume.folders.create(name: "Root")
subfolder = root_folder.children.create(name: "Documents")
```

### Working with Items and Revisions

```ruby
# Create an item with a revision
document = FileSystem::Item.new(name: "Important Document")
document.revision_attributes = { 
  contents: current_user,  # polymorphic association
  number: 1,
  metadata: { importance: "high" }
}
document.creator = current_user  # polymorphic association
document.save

# Add the item to a folder
subfolder.items << document

# Get the current revision
current_revision = document.current

# Add a comment
current_revision.comments.create(
  body: "This looks great!",
  creator: current_user
)

# Create a new revision
document.revision_attributes = {
  contents: current_user,
  number: document.next_revision_number,
  metadata: { importance: "medium" }
}
document.save
```

### Access Control

```ruby
# Grant access
subfolder.grant_access_to(current_user, "read", "write")

# Check permissions
subfolder.accessible_to?(current_user)  # => true
subfolder.authorized?(current_user, "write")  # => true

# Revoke access
subfolder.revoke_access_from(current_user)
```

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [LGPL License](https://www.gnu.org/licenses/lgpl-3.0.en.html). This may or may not make it suitable for you to use, depending on your specific licensing requirements and usage context.
