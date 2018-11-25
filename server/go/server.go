package main

import (
	"context"
	"fmt"
	"log"
	"net"

	"./pb"

	"google.golang.org/grpc"
)

type server struct{}

func (*server) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloReply, error) {

	fmt.Printf("Greet function was involked with %v\n", req)
	firstName := req.GetName()
	result := "Hello " + firstName
	res := &pb.HelloReply{
		Message: result,
	}
	return res, nil
}

func main() {
	lis, err := net.Listen("tcp", "0.0.0.0:50051")
	if err != nil {
		log.Fatalf("Failed to listen %v", err)
	}

	s := grpc.NewServer()

	pb.RegisterGreeterServer(s, &server{})

	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to server: %v", err)
	}

}
