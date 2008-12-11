class Say::Hello {
    has 'response' => ( is => 'ro' );
    method hello($who) { $self->response->body("hello, $who") }
};

my ($req, $res) = @_;
Say::Hello->new(response => $res)->hello('world');
