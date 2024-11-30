module BrawlersHelper
  def rarity_style(rarity_name)
    case rarity_name
    when 'COMMON'     then 'bg-gray-100 text-gray-800'
    when 'RARE'       then 'bg-green-100 text-green-800'
    when 'SUPER RARE' then 'bg-blue-100 text-blue-800'
    when 'EPIC'       then 'bg-purple-100 text-purple-800'
    when 'MYTHIC'     then 'bg-red-100 text-red-800'
    when 'LEGENDARY'  then 'bg-yellow-100 text-yellow-800'
    else                  'bg-indigo-100 text-indigo-800'
    end
  end
end 