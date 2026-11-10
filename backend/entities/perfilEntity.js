import Entity from "./entity.js";

export default class PerfilEntity extends Entity{

    #id;
    #descricao;

    get id(){
        return this.#id;
    }

    set id(value){
        this.#id = value;
    }

    get descricao(){
        return this.#descricao;
    }

    set descricao(value){
        this.#descricao = value;
    }

    constructor(id, descricao){
        super();
        this.#id = id;
        this.#descricao = descricao;
    }

    static toMap(row){
        return new PerfilEntity(row["per_id"],
            row["per_descricao"]
        )
    }

}