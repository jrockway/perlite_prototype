use MooseX::Declare;
use MooseX::AttributeHelpers;

class Perlite::Compiled {
    has 'main_body' => (
        is       => 'ro',
        isa      => 'CodeRef',
        required => 1,
    );

    has 'lexical_setters' => (
        metaclass => 'Collection::Hash',
        is        => 'ro',
        isa       => 'HashRef[CodeRef]',
        default   => sub { +{} },
    );

    has 'declaration_readers' => (
        metaclass => 'Collection::Hash',
        is        => 'ro',
        isa       => 'HashRef[CodeRef]',
        default   => sub { +{} },
    );

    method read_declaration(Str $declaration){
        my $reader = $self->declaration_readers->{$declaration};
        confess "no such declaration '$declaration'" unless $reader;
        return $reader->();
    }

    method set_lexical(Str $lexical, $value){
        my $setter = $self->lexical_setters->{$lexical};
        confess "no such lexical '$lexical'" unless $lexical;
        return $setter->($value);
    }

    # TODO: run in compartment

    method run {
        $self->main_body->();
    }

};

1;
