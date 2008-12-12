use MooseX::Declare;
use MooseX::AttributeHelpers;

class Perlite::Cache {
    use MooseX::Types::Path::Class qw(File);

    has 'entries' => (
        metaclass => 'Collection::Hash',
        is        => 'ro',
        isa       => 'HashRef',
        required  => 1,
        default   => sub { +{} },
        provides  => {
            get => '_get',
            set => '_set',
        },
    );

    has 'hash_function' => (
        is       => 'ro',
        isa      => 'CodeRef',
        required => 1,
        default  => sub {
            sub {
                my $text = shift;
                require Digest::SHA1;
                Digest::SHA1->new->add($text)->hexdigest;
            };
        },
    );

    has 'builder' => (
        is       => 'ro',
        isa      => 'CodeRef',
        required => 1,
    );

    method cache(Str $program){
        my $hash = $self->hash_function->($program);
        my $obj = $self->_get($hash);
        return $obj if defined $obj;

        $obj = $self->builder->($program);
        $self->_set($hash, $obj);
        return $obj;
    }
};

1;
