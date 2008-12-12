class Say::Hello is mutable {
    has 'response' => ( is => 'ro' );
    method hello($who) { $self->response->body("hello, $who") }
};

Say::Hello->new(response => $response)->hello('world');
