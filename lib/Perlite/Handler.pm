use MooseX::Declare;

role Perlite::Handler {
    requires 'run';
    requires 'is_applicable';

    has 'server' => (
        is       => 'ro',
        isa      => 'Perlite::Server',
        required => 1,
    );
};

1;
