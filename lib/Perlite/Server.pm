use MooseX::Declare;
use Path::Class::File;

sub Path::Class::File::extension {
    return [split /[.]/, shift->stringify]->[-1];
}

class Perlite::Server with MooseX::LogDispatch::Levels {
    use HTTP::Engine;
    use MooseX::Types::Path::Class qw(Dir);

    use Perlite::Compiler;

    has 'directory' => (
        is       => 'ro',
        isa      => Dir,
        coerce   => 1,
        required => 1,
    );

    has 'engine' => (
        is         => 'ro',
        isa        => 'HTTP::Engine',
        lazy_build => 1,
    );

    has 'handlers' => (
        is         => 'ro',
        isa        => 'ArrayRef',
        auto_deref => 1,
        default    => sub {
            my $self = shift;
            require Perlite::Handler::Static;
            require Perlite::Handler::Script;
            return [
                Perlite::Handler::Script->new(
                    server   => $self,
                    compiler => Perlite::Compiler->new(
                        lexicals     => ['$request', '$response'],
                        declarations => ['debug'],
                    ),
                ),
                Perlite::Handler::Static->new( server => $self ),
            ];
        },
    );

    method _build_engine {
        return HTTP::Engine->new(
            interface => {
                module => 'ServerSimple',
                args   => {
                    host => 'localhost',
                    port => 3000,
                },
                request_handler => sub {
                    $self->_handle_request(@_);
                }
            },
        );
    }

    method _handle_request($request) {
        my @path = split '/', $request->uri->canonical->path;
        my $file = pop @path;

        my $relevant_file = $self->directory;
        $relevant_file = $relevant_file->subdir($_) for @path;
        $relevant_file = $relevant_file->file($file)->absolute;
        $self->debug("trying to serve $relevant_file");

        my $response = HTTP::Engine::Response->new;
        if ( !-e $relevant_file ) {
            $response->status(404);
            $response->body('not found');
            return $response;
        }

        for my $handler ( $self->handlers ){
            if( $handler->is_applicable($relevant_file) ){
                $handler->run($relevant_file, $request, $response);
                return $response;
            }
        }

        die 'unhandled request';
        return $response;
    }
};

1;
