package br.devopsbootcamp;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

public sealed interface PaymentMethods {

    @GET
    @Path("/transaction/{id}")
    @Produces(MediaType.TEXT_PLAIN)
    String transaction(String id);


    @Path("pix")
    @Tag(name = "PIX", description = "Pix transactions")
    final class PixApi implements PaymentMethods {
        @Inject
        FakeServiceTransaction fakeServiceTransaction;

        @Override
        public String transaction(String id) {
            return fakeServiceTransaction.randomResult(id);
        }
    }

    @Path("ted")
    @Tag(name = "TED", description = "Ted transactions")
    final class TedApi implements PaymentMethods {
        @Inject
        FakeServiceTransaction fakeServiceTransaction;

        @Override
        public String transaction(String id) {
            return fakeServiceTransaction.randomResult(id);
        }
    }

    @Path("boleto")
    @Tag(name = "BOLETO", description = "Boleto transactions")
    final class BoletoApi implements PaymentMethods {
        @Inject
        FakeServiceTransaction fakeServiceTransaction;

        @Override
        public String transaction(String id) {
            return fakeServiceTransaction.randomResult(id);
        }
    }
}