use MooseX::Declare;

class Perlite::Compartment with MooseX::LogDispatch::Levels {
    method eval($code) {
        $self->debug("about to eval\n---\n$code\n---\n");
        return CORE::eval($code) || die $@;
    }
};

1;
