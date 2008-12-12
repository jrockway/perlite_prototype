use MooseX::Declare;
use Perlite::Cache;
use Perlite::Compartment;
use Perlite::Compiled;
use 5.010;

class Perlite::Compiler {
    has 'cache' => (
        is         => 'ro',
        isa        => 'Perlite::Cache',
        lazy_build => 1,
    );

    has 'lexicals' => ( # XXX: scalars only, right now
        is         => 'ro',
        isa        => 'ArrayRef[Str]',
        default    => sub { [] },
        auto_deref => 1,
    );

    has 'declarations' => (
        is         => 'ro',
        isa        => 'ArrayRef[Str]',
        default    => sub { [] },
        auto_deref => 1,
    );

    has 'compartment' => (
        is       => 'ro',
        isa      => 'Perlite::Compartment',
        default => sub { Perlite::Compartment->new },
    );

    method _build_cache {
        return Perlite::Cache->new(
            builder => sub {
                my $code = shift;
                return $self->_compile($code);
            },
        );
    }

    method _define_package {
        state $serial = 0;
        $serial++;
        return "package __COMPILED__::$serial;\nuse MooseX::Declare;\n\n";
    }

    method _declare_lexicals {
        return join '', map { "my $_;\n" } $self->lexicals;
    }

    method _beginlift_declarations {
        return "use Devel::BeginLift qw(".
          (join ' ', $self->declarations).
        ");\n";
    }

    method _define_declaration_functions {
        return join "", map {
            "my \$__DECLARE__$_; sub $_ { \$__DECLARE__$_ = shift }\n"
        } $self->declarations;
    }

    method _return_lexical_setters {
        return '{'. (join "", map {
            "'$_' => sub { $_ = shift },"
        } $self->lexicals). '}';
    }

    method _return_declaration_readers {
        return '{'. (join "", map {
            "'$_' => sub { \$__DECLARE__$_ },"
        } $self->declarations). '}';
    }

    method _compile(Str $program){
        my $code =
          $self->_define_package.
          $self->_declare_lexicals.
          $self->_beginlift_declarations.
          $self->_define_declaration_functions.
          '['.
            $self->_return_lexical_setters. ','.
            $self->_return_declaration_readers. ','.
            "sub {\n#line 1 ORIGINAL\n". # todo: real filename
            "$program }, ".
          ']';

        my $result = $self->compartment->eval($code);
        return Perlite::Compiled->new(
            main_body           => $result->[2],
            lexical_setters     => $result->[0],
            declaration_readers => $result->[1],
        );
    }

    method compile(Str $program) {
        return $self->cache->cache($program);
    }
};

1;
it
