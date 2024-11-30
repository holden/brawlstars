require 'pagy'
require 'pagy/extras/bootstrap'
require 'pagy/extras/overflow'
require 'pagy/extras/items'

# Configure Pagy defaults
Pagy::DEFAULT.merge!(
  items: 30,
  max_items: 100,
  overflow: :last_page
)