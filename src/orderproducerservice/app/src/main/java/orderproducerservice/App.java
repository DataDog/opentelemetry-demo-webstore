/*
 * This Java source file was generated by the Gradle 'init' task.
 */
package orderproducerservice;

import java.util.Properties;
import java.util.Random;
import java.lang.Thread;
import java.lang.InterruptedException;

import org.apache.kafka.common.serialization.StringSerializer;
import org.apache.kafka.common.serialization.ByteArraySerializer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.Producer;

import oteldemo.Demo.*;

public class App {

    public static void main(String[] args) {

        String kafkaAddr = System.getenv("KAFKA_SERVICE_ADDR");
        if (kafkaAddr != null) {
            System.out.println("Using Kafka Broker Address: " + kafkaAddr);
        } else {
            throw new RuntimeException("Environment variable KAFKA_SERVICE_ADDR is not set.");
        }

        Properties props = new Properties();
        props.put("bootstrap.servers", kafkaAddr);
        props.put("acks", "all");
        props.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, ByteArraySerializer.class.getName());

        Producer<String, byte[]> producer = new KafkaProducer<>(props);

        while (true) {
            Random random = new Random();
            try {
                String orderId = "ORDER-" + random.nextInt(1000);
                String shippingTrackingId = "TRACK-" + random.nextInt(1000);
                double shippingCost = 10 + random.nextDouble() * 90;
                OrderResult orderResult = OrderResult.newBuilder()
                        .setOrderId(orderId)
                        .setShippingTrackingId(shippingTrackingId)
                        .setShippingCost(Money.newBuilder()
                                .setCurrencyCode("EUR")
                                .setUnits((long) shippingCost)
                                .setNanos((int) ((shippingCost - (long) shippingCost) * 1e9))
                                .build())
                        .setShippingAddress(Address.newBuilder()
                                .setStreetAddress("21 rue Chateaudun")
                                .setCity("Paris")
                                .setState("Paris")
                                .setCountry("France")
                                .setZipCode("75009")
                                .build())
                        .build();
                ProducerRecord<String, byte[]> record = new ProducerRecord<>("orders", null, orderResult.toByteArray());
                producer.send(record);
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                System.out.println("Message sent successfully!");
            }
            try {
                Thread.sleep(4000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            // producer is never closed because of while loop above. Leaving in case the code changes, to not forget to close producer.
            // producer.close();
        }
    }
}
