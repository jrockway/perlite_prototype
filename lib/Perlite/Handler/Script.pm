use MooseX::Declare;
use Perlite::Compiler;

class Perlite::Handler::Script with Perlite::Handler {
    has 'compiler' => (
        is       => 'ro',
        isa      => 'Perlite::Compiler',
        required => 1,
    );

    method is_applicable($file){
        return 1 if $file->extension eq 'pl';
        return;
    }

    # TODO: eval around compile / run --> error screen
    method run($file, $request, $response){
        my $text = $file->slurp;
        my $script = $self->compiler->compile($file, $text);
        $script->set_lexical('$request' => $request);
        $script->set_lexical('$response' => $response);
        $script->run;
    }
};

1;

1;
