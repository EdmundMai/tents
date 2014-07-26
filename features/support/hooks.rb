Around('@successful_usaepay_and_ups_response') do |scenario, block|
  VCR.use_cassette("checkout/successful_usaepay_and_ups_response") { block.call }
end

Around('@successful_ups_response') do |scenario, block|
  VCR.use_cassette("checkout/successful_ups_response") { block.call }
end

# Around('@unsuccessful_usaepay_purchase_response') do |scenario, block|
#   VCR.use_cassette("checkout/unsuccessful_purchase_response") { block.call }
# end

