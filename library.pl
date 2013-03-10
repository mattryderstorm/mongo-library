#!/usr/bin/perl

use Mojolicious::Lite;
use MongoDB;
use Data::Dumper;
use JSON::Schema;

get '/' => sub { 
    my $self = shift;
    $self->render( text => 'Hello, library users!' );   
};

get '/books' => sub { 
    my $self   = shift;
    my $mongo  = MongoDB::MongoClient->new;  # localhost by default
    my $db     = $mongo->get_database( 'library' );
    my $coll   = $db->get_collection( 'books' );
    my $cursor = $coll->find;                # finds everything

    $self->render( 'books', books_cursor => $cursor, db => $db );
};

get '/books/edit/:id' => sub {
	my $self = shift;
    	my $mongo  = MongoDB::MongoClient->new;  # localhost by default
	my $id = $self->stash('id');
	#my $db     = $mongo->get_database( 'library' );
    	#my $coll   = $db->get_collection( 'books' );
    	#my $cursor = $coll->find_one( name => $id );                # finds everything
	$self->render(item => $id, booday => 'boo');
};

post '/books' => sub { 
    my $self   = shift	;
    my $mongo  = MongoDB::MongoClient->new;
    my $rule = read_file();
    my $schema = JSON::Schema->new(from_json($rule));
    my $new_book = { title   => scalar $self->param( 'title' ),
                     author  => scalar $self->param( 'author' ),
                     genre   => [ $self->param( 'genre' ) ],
                     publication => { 
                         name     => scalar $self->param( 'pub_name' ),
                         location => scalar $self->param( 'pub_location' ),
                         date     => DateTime->new( 
                             month => scalar $self->param( 'pub_month' ),
                             year  => scalar $self->param( 'pub_year' )
                         )
                     }
                   };
    my $result = $schema->validate($new_book);
	my $errors = {};
    if ($result) {	
	    $mongo->get_database( 'library' )
	      ->get_collection( 'books' )->insert( $new_book );
	                   # finds everything
    } else {
   	$errors = { 'Errors Received' => $result->errrors };
    }
	    my $db     = $mongo->get_database( 'library' );
	    my $coll   = $db->get_collection( 'books' );
	    my $cursor = $coll->find; 
	    $self->render( 'books', books_cursor => $cursor, db => $db, errors => $errors );
};

get '/books/:genre' => sub { 
    my $self   = shift;
    my $genre  = $self->stash( 'genre' );

    my $mongo  = MongoDB::MongoClient->new;
    my $cursor = $mongo->get_database( 'library' )
      ->get_collection( 'books' )
        ->find( { genre => $genre } );

    $self->render( 'books', books_cursor => $cursor, db => $mongo->get_database( 'library' ) );
};

app->start;

__DATA__
@@ books.html.ep

<h1>Here is your list of books!</h1>
<ul>
<% while( my $doc = $books_cursor->next ) {  %>
<%   my $author = $db->get_collection( 'authors' )->find_one( { _id => $doc->{author} } ); %>
<li><%= $doc->{title} %> by 
<a href="/author/<%= $author->{slug} %>"> <%= $author->{first_name} %> <%= $author->{last_name} %>  </a>
<a href="/books/edit/<%= $doc->{title} %>"> xxx <%= $doc->{title} %> </a>

</li>
<% } %>
<form method='post' action='/books/'>
	<dl>

		<dt> Title </dt>
		<dd> <input type='text' name='title' value=''></dd>
		<dt> Author </dt>
		<dd> <input type='text' name='author' value=''></dd>
		<dd> Genre: </dd>
		<dd> <input type='text' name='genre' value=''></dd>
		Publication
		<dt> Name </dt>
		<dd> <input type='text' name='pub_name' /> </dd>
		<dt> Location </dt>
		<dd> <input type='text' name='pub_location' /> </dd>
		<dt> Pub Month </dt>
		<dd> <input type='text' name='pub_month' /> </dd>
		<dt> Pub Year </dt>
		<dd> <input type='text' name='pub_year' /> </dd>
		<input type='submit' value='Sulbmit' />
		<input type='reset' value='Reset' />
	</dl>
</form>
</ul>

@@ bookseditid.html.ep
<%= $item %>
xxx
<%= $booday %>
xxx
