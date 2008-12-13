use MooseX::Declare;
use MooseX::AttributeHelpers;

class Perlite::Cache {
    use MooseX::Types::Path::Class qw(File);

    has 'entries' => (
        metaclass => 'Collection::Hash',
        is        => 'ro',
        isa       => 'HashRef[ArrayRef]',
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

    method cache($file, $text){
        my $entry = $self->_get("$file") || [];
        my ($cached_hash, $cached_obj) = @$entry;

        my $text_hash = $self->hash_function->($text);
        return $cached_obj if defined $cached_hash && $text_hash eq $cached_hash;

        my $new_obj = $self->builder->($file, $text);
        $self->_set("$file", [$text_hash, $new_obj]);
        return $new_obj;
    }
};

1;
