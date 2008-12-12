use MooseX::Declare;
class Perlite::Handler::Static with Perlite::Handler {
    use MIME::Types;
    sub _type($){
        my $extension = shift;
        return MIME::Types->new->mimeTypeOf($extension)->type;
    }
    use namespace::clean -except => 'meta';

    method is_applicable($file){
        return 1;
    }

    method run($file, $request, $response){
        $response->content_type( _type $file->extension );
        $response->body($file->openr);
    }
};

1;
