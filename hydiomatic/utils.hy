;; hydiomatic -- The Hy Transformer
;; Copyright (C) 2014  Gergely Nagy <algernon@madhouse-project.org>
;;
;; This library is free software: you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.
;;
;; This library is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public
;; License along with this program. If not, see <http://www.gnu.org/licenses/>.

(import [hy [HyExpression HySymbol HyInteger HyString HyDict
             HyLambdaListKeyword HyKeyword HyCons]])

(defn walk [inner outer form]
  (cond
   [(instance? HyExpression form)
    (outer (HyExpression (map inner form)))]
   [(instance? HyDict form)
    (HyDict (outer (HyExpression (map inner form))))]
   [(cons? form)
    (outer (cons (inner (first form))
                 (inner (rest form))))]
   [(instance? list form)
    ((type form) (outer (HyExpression (map inner form))))]
   [true (outer form)]))

(defn identity [f] f)

(defn prewalk [f form]
  (walk (fn [x] (prewalk f x)) identity (f form)))

(defn -pprint [form]
  (cond
   [(instance? HyExpression form)
    (+ "(" (.join " " (map -pprint form)) ")")]
   [(or (instance? HySymbol form) (instance? HyLambdaListKeyword form))
    (str form)]
   [(or (instance? HyInteger form) (integer? form))
    (str form)]
   [(instance? HyKeyword form)
    (str (rest (rest form)))]
   [(or (instance? HyString form) (string? form))
    (str (+ "\"" (str form) "\""))]
   [(or (instance? HyDict form) (instance? dict form))
    (+ "{" (.join " " (map -pprint form)) "}")]
   [(instance? list form)
    (+ "[" (.join " " (map -pprint form)) "]")]
   [(cons? form)
    (+ "(" (-pprint (first form)) " . " (-pprint (rest form)) ")")]
   [true
    nil]))

(defn hypprint [form &optional [outermost false]]
  (if outermost
    (map hypprint form)
    (print (-pprint form))))
