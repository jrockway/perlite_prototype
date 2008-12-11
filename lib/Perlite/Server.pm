use MooseX::Declare;

class Perlite::Server with MooseX::LogDispatch::Levels {
    use HTTP::Engine;
    use MooseX::Types::Path::Class qw(Dir);
    use String::TT qw/tt strip/;

    #use Perlite::Compiler;
    #use Perlite::Cache;
    #use Perlite::Run;

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

    sub _build_engine {
        my $self = shift;
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

    sub _handle_request {
        my ($self, $request) = @_;
        my @path = split '/', $request->uri->canonical->path;
        my $file = pop @path;

        my $relevant_file = $self->directory;
        $relevant_file = $relevant_file->subdir($_) for @path;
        $relevant_file = $relevant_file->file($file)->absolute;
        $self->debug("trying to serve $relevant_file");

        my $response = HTTP::Engine::Response->new;
        if( !-e $relevant_file ){
            $response->status(404);
            $response->body('not found');
            return $response;
        }

        if ( $relevant_file !~ /[.]pl$/ ){
            # figure out content-type
            $response->body( $relevant_file->openr );
            return $response;
        }

        # finally, an app
        my $text = $relevant_file->slurp;
        my $sub = eval qq{ use MooseX::Declare; sub { $text };};
        confess "failed to compile: $@" if !$sub;

        $sub->($request, $response);
        return $response;
    }
};

1;
