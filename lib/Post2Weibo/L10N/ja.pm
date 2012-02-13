package Post2Weibo::L10N::ja;
use strict;
use base 'Post2Weibo::L10N';
use vars qw( %Lexicon );

our %Lexicon = (
    'Post entry to Weibo.' => 'ブログ記事/ウェブページをWeiboへポストします。',
    'An error occurred while trying to post to Weibo : ([_1])[_2]' => 'Weiboへの投稿中にエラーが発生しました : ([_1])[_2]',
    'Post entry to Weibo' => 'ブログ記事をWeiboへポストする。',
    'Post page to Weibo' => 'ウェブページをWeiboへポストする。',
    'Weibo template' => '投稿テンプレート',
    'Add Hashtag' => 'ハッシュタグ',
    'URL and hashtag will automatically be added.' => 'URL やハッシュタグは自動的に付与されます。',
    'Comma district switching off, space is removed at posting.' => 'カンマ区切り(スペースは取り除かれます)',
    'ex: foo, bar, hoge' => '例: foo, bar, hoge',
);

1;