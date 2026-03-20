package spring.db.dbbenchmark;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class DbBenchmarkApplication {

    public static void main(String[] args) {
        SpringApplication.run(DbBenchmarkApplication.class, args);
    }

}
