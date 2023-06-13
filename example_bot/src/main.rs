use rand::Rng;

#[derive(Debug)]
enum Action{
    Cooperate,
    Defect,
}

fn main() {
    let action:Action;
    let loyalty:f64 = 0.0;
    let mut rng = rand::thread_rng();

    //Take action randomly based on loyalty
    //loyalty 1.0 => always faithful
    //loyalty 0.0 => always deceitful

    if loyalty > rng.gen(){
        action = Action::Cooperate;
    }else{
        action = Action::Defect;
    }

    println!("{:?}", action);
}