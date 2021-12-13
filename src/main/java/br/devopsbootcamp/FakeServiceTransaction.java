package br.devopsbootcamp;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class FakeServiceTransaction {


    public String randomResult(String id){
        return Math.random() > 0.5 ? "PENDING" : "SUCCESS";
    }
}
