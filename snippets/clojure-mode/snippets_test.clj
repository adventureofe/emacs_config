(defn area-circle-radius
  [radius]
  (* Math/PI (Math/pow radius 2)))

(defn area-circle-circumference
  [circumference]
  (/ (Math/pow circumference 2) (* 4 Math/PI)))

(defn area-hexagon
  [side]
  (* (Math/pow side 2) (/ (* 3 (Math/sqrt 3)) 2)))
(defn area-octagon
  [side]
  (* 2 (Math/pow side 2) (+ 1 (Math/sqrt 2))))
(defn area-pentagon
  [side]
  (* 0.25 (Math/sqrt ( * 5 ( + 5 (* 2 (Math/sqrt 5))))) (Math/pow side 2)))
(defn area-equal-triangle
  [side]
  (* (Math/pow side 2) (/ (Math/sqrt 3) 4)))
