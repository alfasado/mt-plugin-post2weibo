package Post2Weibo::Plugin;
use strict;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON qw/decode_json/;

sub _post2weibo {
    my ( $cb, $app, $obj, $original ) = @_;
    return 1 if $original && $original->status == MT::Entry::RELEASE();
    return 1 unless $obj->status == MT::Entry::RELEASE();
    my $plugin = MT->component( 'Post2Weibo' );
    my $blog_id = $obj->blog_id;
    my $source = $plugin->get_config_value( 'weibo_source', 'blog:' . $blog_id );
    my $username = $plugin->get_config_value( 'weibo_username', 'blog:' . $blog_id );
    my $password = $plugin->get_config_value( 'weibo_password', 'blog:' . $blog_id );
    my $post_page = $plugin->get_config_value( 'weibo_post_page', 'blog:' . $blog_id );
    my $post_entry = $plugin->get_config_value( 'weibo_post_entry', 'blog:' . $blog_id );
    my $template = $plugin->get_config_value( 'weibo_template', 'blog:' . $blog_id );
    my $hashtag = $plugin->get_config_value( 'weibo_hashtag', 'blog:' . $blog_id );
    my $class = $obj->class;
    if ( ( $class eq 'entry' ) && (! $post_entry ) ) {
        return 1;
    }
    if ( ( $class eq 'page' ) && (! $post_page ) ) {
        return 1;
    }
    # my $title = $obj->title;
    # my $permalink = $obj->permalink;
    # my $weibo = $title . ' ' . $permalink;
    require MT::Template;
    require MT::Template::Context;
    my $tmpl = MT::Template->new;
    $tmpl->name( 'Post2Weibo' );
    $tmpl->text( $template );
    $tmpl->blog_id( $obj->blog_id );
    my $ctx = MT::Template::Context->new;
    $ctx->stash( 'blog', $obj->blog );
    $ctx->stash( 'blog_id', $blog_id );
    $ctx->stash( 'local_blog_id', $blog_id );
    $ctx->stash( 'entry', $obj );
    $ctx->stash( 'category', $obj->category );
    $ctx->stash( 'author', $obj->author );
    my $weibo = $tmpl->build( $ctx );
    if ( $hashtag ) {
        my $weibo_hashtag = '';
        my @each_tags = split( ',', $hashtag );
        @each_tags = map { $_ =~ s/[\s#]//g; $_; } @each_tags;
        for my $tag ( @each_tags ) {
            $weibo_hashtag .= '#' . $tag . '# ';
        }
        $weibo .= ' ' . $weibo_hashtag;
    }
    $weibo .= ' ' . $obj->permalink;
    my $req = POST( 'http://api.t.sina.com.cn/statuses/update.json?source=' . $source, [ status => $weibo ] );
    $req->authorization_basic( $username, $password );
    my $ua = LWP::UserAgent->new;
    my $res = $ua->request( $req );
    my $json = $res->content;
    my $data = decode_json( $json );
    if ( my $error_code = $data->{ error_code } ) {
        my $error = $data->{ error };
        $app->log( {
            message => $plugin->translate( 
                'An error occurred while trying to post to Weibo : ([_1])[_2]', $error_code, $error ),
            blog_id => $obj->blog_id,
            author_id => $app->user->id,
            class => 'post2weibo',
            level => MT::Log::ERROR(),
        } );
    }
    return 1;
}

1;