package com.srrfrr.api.repositories.main.rating;

import com.srrfrr.api.entities.main.RatingValues;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface RatingValuesRepository extends JpaRepository<RatingValues, UUID> {

}