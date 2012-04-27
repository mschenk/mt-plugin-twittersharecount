package TwitterShareCount::Plugin;

use LWP::Simple;
use JSON qw( decode_json );

sub count_twitter_shares {
	my $mt = MT->instance;
	my $plugin = MT->component("TwitterShareCount");
	$iter = MT::Blog->load_iter();   
	while (my $blog = $iter->()) { 
		# For each of the blogs in the list, check if they have the 'check_fb_shares' plugin
		# setting checked or not
		my $scope = "blog:" . $blog->id;
		if ($plugin->get_config_value('count_tw_shares',$scope)){
			# If the blog has the 'count_tw_shares' option checked, loop over all entries and check them.
			$entriesiter = MT::Entry->load_iter({blog_id => $blog->id});
			while (my $entry = $entriesiter->()) {	
				my $twresult = get("http://urls.api.twitter.com/1/urls/count.json?url=".$entry->permalink);
				MT->log("TwitterSharecount for ".$entry->permalink." ".$twresult);
				my $decoded_json = decode_json( $twresult );
				if ($decoded_json->{'count'}){
					$entry->twshares($decoded_json->{'count'});
					$entry->save;
				}
			}
		}
	}
	
}

sub _hdlr_entrytwshares {
	my ($ctx, $args) = @_;
	
	my $entry = $ctx->stash('entry')
        || $ctx->error(MT->translate('You used an [_1] tag outside of the proper context.', 'EntryFBShares'));
        
        return $entry->twshares;
}

1;
