package org.tiger.calcite.example4flyway_jpa_demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.tiger.calcite.example4flyway_jpa_demo.entity.User;

public interface UserRepository extends JpaRepository<User, Long> {

}
