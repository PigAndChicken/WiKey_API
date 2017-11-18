module WiKey
  
  module Wiki
    
    class CatalogMapper
      
      def initialize(gateway)
        @gateway = gateway
      end
      
      def load(topic)
        article_data = @gateway.article_data(topic)
        key = article_data['query']['pages'].keys[0]
        article_data = article_data['query']['pages'][key]
        build_entity(article_data)
      end
      
      def build_entity(article_data)
        DataMapper.new(article_data).build_entity
      end
      
      class DataMapper
      
        def initialize(article_data)
          @article_data = article_data
        end
        
        def build_entity
          catalogs = build_catalogs
          catalogs_array = []
          catalogs_array.push(
            Entity::Catalog.new(
              name: 'default',
              topic: @article_data['title']
            )
          )
          catalogs.each do |catalog|
            break if catalog.content == 'See also'
            catalog = Entity::Catalog.new(
              name: catalog.content,
              topic: @article_data['title'],
            )
            catalogs_array.push(catalog)
          end
          catalogs_array
        end
        
        private
        def build_catalogs
          html_doc = Nokogiri::HTML(@article_data['extract'])
          catalogs = html_doc.css('h2')
          catalogs
        end
        
      end
    end
  end
end